with stg_page_views as (select * from {{ ref('stg_page_views') }})

, final as (
    select distinct

        -- Use a natural key for the primary key here
        path as web_page_id
        , path
        , concat('https://www.synthesia.io', path) as url

        -- These categorisations are demonstrative and would require working with the business / developers to refine
        , case
            when path like '%account%' or path like '%/MY.ACOOUN%' then 'account management'
            when path like '%actors%' then 'actors'
            when path like '%video%' then 'project creation and management'
            when path like '%vidmeo%' then 'project creation and management'
            when path like '%library%' then 'project creation and management'
            when path like '%templates%' then 'project creation and management'
            when path like '%trash%' then 'project creation and management'
            when path like '%folder%' then 'project creation and management'
            when path like '%examples%' then 'onboarding'
            when path like '%onboarding%' then 'onboarding'
            when path like '%onboarding%' then 'onboarding'
            when path like '%missing-subs%' then 'missing subscription'
            when path like '%sign%' then 'sign in'
            when path like '%sin-in%' then 'sign in'
            when path like '%login%' then 'sign in'
            when path like '%questionnaire%' then 'sign in'
            when path like '%subscription%' then 'sign in'
            when path like '%first-time%' then 'sign in'
            when path like '%password%' then 'reset password'
            else 'other'
        end as page_category
        
        -- This column captures the order in which steps are expected to be taken when a user signs up for the product
        -- Used for sorting the pages
        , case
            when path like '%pricing%' then 10
            when path like '%sign-up%' then 20
            when path like '%login%' then 20
            when path like '%missing-subs%' then 30
            when path like '%first-time-visit%' then 40
            when path like '%questionnaire%' then 50
            else null
        end as sign_up_process_ordinal
    from stg_page_views
)

select * from final
