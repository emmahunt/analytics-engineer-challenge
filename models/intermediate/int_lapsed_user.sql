with page_views as (select * from {{ ref('stg_page_views') }})

-- Calculated the lapse date of users based on their latest page view date
, lapsed_date as (
    select
        user_identifier
        , max(received_at)::date as latest_page_view
        , case

            -- We only have page view data up until the 14th of December, so can't know if a user is active or not based on presence of page views after this date. In a real world scenario with continuous data this clause would be adjust to compare to current date
            when
                dateadd(day, 7, max(received_at)::date) > '2022-12-14'
                then null
            
            -- The user lapsed date is 7 days after their last page view
            else dateadd(day, 7, max(received_at)::date)
        end as lapsed_date
    from page_views
    group by 1
)

, final as (
    select 
        *
        , case 
            when lapsed_date is null then 1
            else 0 
        end as is_active
    from lapsed_date
)

select * from final
