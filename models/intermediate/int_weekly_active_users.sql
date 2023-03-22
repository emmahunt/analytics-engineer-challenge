with page_view as (select * from {{ ref('fact_page_view') }})
, users as (select * from {{ ref('dim_user') }})

, weekly_activity as (
    select 
        users.user_cohort_week
        , users.user_id
        , users.segment

        -- Bucket the data into 'periods' / how many weeks after the user was created
        , cast(
            datediff(day, users.created_at, page_view.received_at) / 7 as int
        ) as weeks_since_first_active

        -- Flag this row as the user being active in the period, as there was at least 1 page view
        -- Use a 1 rather than count of page views so that we can sum over this colum later on
        , 1 as active_during_period
        , null as cohort_size
    from
        page_view

    -- Exclude records we can't map to the users table
    -- This reduces the dataset we can work with, but is necessary if we want to examine the user segments
    inner join users 
        on page_view.user_id = users.user_id
    
    -- There are some users who had page view activity before the timestamp of their user account being created
    -- Ignore these cases: for this definition, we are only considering activity in the week of, or after the user has been 'acquired' via creating a user account
    where
        cast(datediff(day, users.created_at, page_view.received_at) / 7 as int)
        >= 0
    group by 1, 2, 3, 4

)

select * from weekly_activity
