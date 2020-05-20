# Sisyphus
An alternate version of the King of the Hill game but where the buyout price declines with time. Behodler's Scarcity is the native token, not Eth.

## Why?
When Behodler was launched, the liquidity reserves existed in a bit of a chicken and egg scenario: not enough liquidity to justify the gas price which means no liquidity added.
Users needed an additional reason to purchase Scarcity. 

### Rules
1. At any point in time there is a reigning monarch who has a buyout price.
2. The initial buyout price is multiplied by 0.01% to form the decay delta.
3. The buyout price declines by 1 decay delta per day so that after 100 days, the price is zero.
4. To become the reigning monarch you have to pay the buyout price. The current monarch receives 66% of the buyout price. The remaining 34% is burnt.
5. Once the new monarch is established, the new buyout price is set at 4 times the price paid to become monarch.
6. These parameters might change to accomodate the preferences of real world humans.


## Why is Scarcity burnt during transfer?
Behodler increases its liquidity reserves of various tokens by having Scarcity burn. Sisyphus can accelerate this process.
