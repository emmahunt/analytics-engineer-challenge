with stg_page_views as (select * from {{ ref('stg_page_views') }})

-- Join to the user-identifier mapping table to derive the user_id: a foreign key to the user dimension in this table
, next_page_view as (
    select
        {{ dbt_utils.generate_surrogate_key( 
            ['stg_page_views.user_identifier', 'stg_page_views.path', 'stg_page_views.received_at']
        ) }} as page_view_id
        , stg_page_views.path
        , stg_page_views.received_at
        , stg_page_views.user_identifier as user_id
        
        -- Calculate some facts
        , lead(stg_page_views.received_at) over (
            partition by stg_page_views.user_identifier
            order by stg_page_views.received_at asc
        ) as next_page_view_at
    from stg_page_views
)

-- Partition up the page views into sessions
-- Defined as a series of page views where no 2 consecutive page views are more than 30 minutes apart
, calculate_session_id as (
    select
        page_view_id
        , path
        , received_at
        , next_page_view_at
        , user_id

        -- Generate a new incrementing integer for each new session
        , conditional_true_event(
            datediff(
                'minute'
                , lag(received_at) over (
                    partition by user_id 
                    order by received_at asc
                )
                , received_at
            ) > 30
        ) 
        over (
            partition by user_id 
            order by received_at asc
        ) as new_session_increment
    from next_page_view
)

, final as (
    select 
        page_view_id
        , path
        , received_at
        
        -- Some additional facts about the page view
        , row_number() over (
            partition by user_id, new_session_increment
            order by received_at asc
        ) as page_view_ordinal_in_session
        , case
            when 
                lead(new_session_increment) over (
                    partition by user_id
                    order by received_at asc
                ) != new_session_increment 
                then null
            else datediff('second', received_at, next_page_view_at)
        end as dwell_time_in_seconds

        -- Foreign keys at end of table
        , path as web_page_id
        , user_id
        , {{ dbt_utils.generate_surrogate_key(
            ['user_id', 'new_session_increment']
        ) }} as session_id
    from calculate_session_id
)

select * from final
