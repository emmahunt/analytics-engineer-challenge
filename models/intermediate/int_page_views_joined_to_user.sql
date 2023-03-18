with page_views as (select * from {{ ref('stg_page_views') }})
, users as (select * from {{ ref('stg_users') }})

-- Identify the sign up events on the page view side
-- so we can link the page view sign up event to the corresponding row in the users table
, sign_up_page_views as (
    select 
        user_identifier
        , received_at
    from page_views

    -- Limit to just page views on the first-time-visit page as a proxy for a user account being created 
    -- This is based on the understanding that a successful user sign up flow is indicated by a land on the /first-time-visit page
    where page_path = '/first-time-visit'

    -- There are 2 users who have multiple first time visit events
    -- Limit to just the latest / most recent sign up event for each user
    qualify row_number() over (partition by user_identifier order by received_at desc) = 1  
)

, final as (
    select 
        supv.user_identifier
        , users.user_id
    from sign_up_page_views as supv
    left join users

        -- Join based on the timestamp - in the majority of cases, the user record being created will be within 10 seconds of the sign up page view event
        on timestampdiff(second, users.created_at::timestamp, supv.received_at::timestamp) between -10 and 10
    where users.user_id is not null
    group by 1, 2
)

select * from final
