| EXECUTE THE BELOW KQL IN AZURE RESOURCE GRAPH EXPLORER:- |
| :---------: |

| USE CASE #4:- |
| :---------: |
| The Query Outputs the Defender Secure Score of every subscription, gives each subscription the appropriate weight, and calculates one overall Secure Score for the Azure environment. |


```
SecurityResources
| where type =~ 'microsoft.security/securescores'
| where name =~ 'ascScore'
| extend
    scorePercentage = todouble(properties.score.percentage),
    subscriptionWeight = todouble(properties.weight)
| where isnotnull(scorePercentage)
| where isnotnull(subscriptionWeight)
| where subscriptionWeight > 0
| summarize
    weightedScore = sum(scorePercentage * subscriptionWeight),
    totalWeight = sum(subscriptionWeight),
    subscriptionCount = dcount(subscriptionId)
| project
    secureScore = round(weightedScore / totalWeight * 100.0, 2),
    subscriptionCount,
    totalWeight
```
