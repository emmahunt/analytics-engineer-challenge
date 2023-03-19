with page_views as (select * from {{ ref('stg_page_views') }})
, users as (select * from {{ ref('stg_users') }})
, dim_web_page as (select * from {{ ref('dim_web_page') }})

-- Identify the sign up events on the page view side
-- so we can link the page view sign up event to the corresponding row in the users table
, sign_up_page_views as (
    select 
        page_views.user_identifier
        , page_views.received_at
    from page_views
    left join dim_web_page
        on page_views.path = dim_web_page.path

    -- Limit to just page views on a set of paths related to account creation as a proxy for a user account being created 
    -- This is based on the understanding that a user account will be created in the "back end" / user management system shortly after a front end event on a set of pages related to account creation
    where dim_web_page.page_category = 'account management'
)

, final as (
    select 
        supv.user_identifier
        , users.user_id
    from users
    left join sign_up_page_views as supv

        -- The only way to attempt to match users in the two systems is by the timestamp: in this case, allow for 65 seconds between the web page event and the user creation in the back end system
        -- This is likely an overly generous time window, but even so only 40% of the users can be matched
        on
            timestampdiff(
                second, supv.received_at::timestamp, users.created_at::timestamp
            ) between -5 and 60
    where supv.user_identifier is not null
    group by 1, 2
    
    -- Deduplicate the matches so that the relationship between user_id and user_identifier is 1:1
    qualify
        row_number() over (
            partition by users.user_id
            order by supv.user_identifier asc
        ) = 1  
        and 
        row_number() over (
            partition by supv.user_identifier
            order by users.user_id asc
        ) = 1  
)

select * from final
