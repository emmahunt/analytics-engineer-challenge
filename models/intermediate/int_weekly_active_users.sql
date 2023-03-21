with page_view as (select * from {{ ref('fact_page_view') }})
, users as (select * from {{ ref('dim_user') }})

, weekly_activity as (
    select 
        users.user_cohort_week
        , users.user_id
        , users.segment
        , cast(datediff(day, users.created_at, page_view.received_at) / 7 as int) as weeks_since_first_active
        , 1 as active_during_period
        , null as cohort_size
    from page_view

    -- Exclude records we can't map to the users table
    -- This reduces the dataset we can work with, but is necessary if we want to examine the user segments
    inner join users 
        on page_view.user_id = users.user_id
    
    -- There are some users who had page view activity before the timestamp of their user account being created
    -- Ignore these cases: for this definition, we are only considering activity after the user has been 'acquired' via creating a user account
    where users.created_at <= page_view.received_at
    group by 1, 2, 3, 4


)

select * from weekly_activity
