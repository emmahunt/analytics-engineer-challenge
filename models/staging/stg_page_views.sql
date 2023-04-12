with raw_data as (
    select *
    from {{ ref('pages_views') }}
)

-- Change column names
, final as (
    select
        case
            when name like '%account%' or name like '%/MY.ACOOUN%' then '/my_account'
            when name like '%actors%' then '/template'
            when name like '%video%' then '/presentation'
            when name like '%vidmeo%' then '/presentation'
            when name like '%library%' then '/folder'
            when name like '%templates%' then '/themes'
            when name like '%trash%' then '/bin'
            when name like '%folder%' then '/folder'
            when name like '%examples%' then '/onboarding'
            when name like '%onboarding%' then '/onboarding'
            when name like '%onboarding%' then '/onboarding'
            when name like '%missing-subs%' then '/add_payment_details'
            when name like '%sign%' then '/signup'
            when name like '%sin-in%' then '/signup'
            when name like '%login%' then '/login'
            when name like '%questionnaire%' then '/survey'
            when name like '%subscription%' then '/subscription'
            when name like '%first-time%' then '/welcome'
            when name like '%password%' then '/password'
            else '/'
        end as path
        , dateadd('minute', uniform(0, 29, random()), received_at) as received_at
        , {{ dbt_utils.generate_surrogate_key(['user_id', 'randstr(5, random())']) }} as user_identifier
    from raw_data

    -- Remove true duplicate page views: the pages at the same exact time, by the same user on the same page
    qualify
        row_number() over (
            partition by user_id, name, received_at
            order by received_at asc
        ) = 1

)

select * from final
