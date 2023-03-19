select * 
from {{ metrics.calculate(
    metric('new_users'),
    grain='week',
) }}