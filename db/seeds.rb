# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Campaign.create! name: "Phala Kusama crowdloan",
                 chain: :kusama,
                 parachain_id: 2004,
                 cap: 150_000,
                 hard_cap: 150_000_000,
                 start_block: 7_687_000, # Placeholder
                 end_block: 100_000_000, # Placeholder 8_467_200 for first wave
                 stringify_total_reward_amount: "100,000,000 PHA",
                 reward_strategy: "1",
                 early_bird_until: Date.new(2021, 6, 23),
                 estimate_first_releasing_in: Date.new(2021, 8, 1),
                 estimate_end_releasing_in: Date.new(2022, 7, 1),
                 first_releasing_percentage: 34,
                 estimate_releasing_days_interval: 30

State.current_block_num(chain: :kusama).update integer_value: 7_687_000

# 6/16/2021
State.coin_stake_participating_rate(symbol: "KSM").update! decimal_value: 47.88
State.coin_stake_apr(symbol: "KSM").update! decimal_value: 14.21
State.coin_stake_participating_rate(symbol: "DOT").update! decimal_value: 62.83
State.coin_stake_apr(symbol: "DOT").update! decimal_value: 13.25

campaign = Campaign.create! name: "Phala test crowdloan",
                            chain: :dev,
                            parachain_id: 2000,
                            cap: 15000,
                            hard_cap: 100000,
                            start_block: 1,
                            end_block: 22000,
                            stringify_total_reward_amount: "100,000,000 PHA",
                            reward_strategy: "1",
                            early_bird_until: Date.new(2021, 6, 23),
                            estimate_first_releasing_in: Date.new(2021, 6, 1),
                            estimate_end_releasing_in: Date.new(2022, 6, 1),
                            first_releasing_percentage: 34,
                            estimate_releasing_days_interval: 30
campaign.milestones.create! estimates_at: Time.parse("2021-5-1"), title: "M1"
campaign.milestones.create! estimates_at: Time.parse("2021-6-1"), title: "M2"
campaign.milestones.create! estimates_at: Time.parse("2021-7-1"), title: "M3"
campaign.competitors.create! parachain_ids: %w[2001 2002], end_block: 22000
