with stg_page_views as (select * from {{ ref('stg_page_views') }})
, mapping_table as (select * from {{ ref('int_page_views_joined_to_user') }})

-- Join to the user-identifier mapping table to derive the user_id: a foreign key to the user dimension in this table
, mapping_table_join as (
    select
        {{ dbt_utils.generate_surrogate_key( ['stg_page_views.user_identifier', 'stg_page_views.page_path', 'stg_page_views.received_at']) }} as page_view_id
        , stg_page_views.page_path
        , stg_page_views.received_at
        , stg_page_views.user_identifier
        
        -- Calculate some facts
        , lead(stg_page_views.received_at) over (
            partition by stg_page_views.user_identifier
            order by stg_page_views.received_at asc
        ) as next_page_view_at
        , mapping_table.user_id
    from stg_page_views
    left join mapping_table
        on stg_page_views.user_identifier = mapping_table.user_identifier
)

-- Partition up the page views into sessions
-- Defined as a series of page views where no 2 consecutive page views are more than 30 minutes apart
, calculate_session_id as (
    select
        page_view_id
        , page_path
        , received_at
        , user_identifier
        , next_page_view_at

        -- Generate a new incrementing integer for each new session
        , conditional_true_event(
                datediff(
                    'minute'
                    , lag(received_at) over (
                        partition by user_identifier 
                        order by received_at asc
                    )
                    , received_at
                ) > 30
            ) 
            over (
                partition by user_identifier 
                order by received_at asc
            ) as new_session_increment
        , user_id
    from mapping_table_join
)

, final as (
    select 
        page_view_id
        , page_path
        , received_at

        -- This column could be excluded for true "normalisation" of the fact table
        -- In this case, as the table is not very wide I will leave it in
        , user_identifier
        
        -- Some additional facts about the page view
        , row_number() over (
            partition by user_identifier, new_session_increment
            order by received_at asc
        ) as page_view_ordinal_in_session
        , case
            when lead(new_session_increment) over (
                partition by user_identifier
                order by received_at asc
            ) != new_session_increment then null
            else datediff('second', received_at, next_page_view_at)
        end as dwell_time_in_seconds

        -- Foreign keys at end of table
        , user_id
        , {{ dbt_utils.generate_surrogate_key(['user_identifier', 'new_session_increment']) }} as session_id
    from calculate_session_id
)

select * from final
