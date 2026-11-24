| EXECUTE THE BELOW KQL IN AZURE RESOURCE GRAPH EXPLORER:- |
| :---------: |

| USE CASE #3:- |
| :---------: |
| The Query Outputs __ALL__ the Subscription Secure Score % to which the Identity has access to it with more granular details. |

__Note:-__

__The Additional Details include:-__
- Subscription ID
- Current Score
- Maximum Score
- Percentage from API
- Calculated Percentage
- Subscription Weight

```
SecurityResources
| where type =~ 'microsoft.security/securescores'
| where name =~ 'ascScore'
| extend
    currentScore = todouble(properties.score.current),
    maximumScore = todouble(properties.score.max),
    percentageFromAPI = todouble(properties.score.percentage) * 100.0,
    calculatedPercentage = iff(
        todouble(properties.score.max) == 0,
        0.0,
        todouble(properties.score.current) /
        todouble(properties.score.max) * 100.0
    ),
    subscriptionWeight = todouble(properties.weight)
| project
    subscriptionId,
    currentScore,
    maximumScore,
    percentageFromAPI = round(percentageFromAPI, 4),
    calculatedPercentage = round(calculatedPercentage, 4),
    subscriptionWeight
| join kind=leftouter (
    ResourceContainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project
        subscriptionId,
        subscriptionName = name
) on subscriptionId
| project
    subscriptionId,
    subscriptionName,
    currentScore,
    maximumScore,
    percentageFromAPI,
    calculatedPercentage,
    subscriptionWeight
| order by subscriptionWeight desc
```
