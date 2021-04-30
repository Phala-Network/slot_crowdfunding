# frozen_string_literal: true

class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.all

    render json: {
      campaigns: @campaigns.map { |campaign| serialize_campaign campaign }
    }
  end

  def show
    @campaign = Campaign.find(params[:id])

    render json: {
      campaign: serialize_campaign(@campaign),
      meta: serialize_campaign_meta(@campaign)
    }
  end

  private

    def serialize_campaign(campaign)
      {
        id: campaign.id,
        name: campaign.name,
        parachain_id: campaign.parachain_id,
        cap: campaign.cap.to_f,
        hard_cap: campaign.hard_cap.to_f,
        start_block: campaign.start_block,
        end_block: campaign.end_block,
        total_reward_amount: campaign.stringify_total_reward_amount,
        raised_amount: campaign.raised_amount.to_f.truncate(4)
      }
    end

    def serialize_campaign_milestone(milestone)
      {
        estimates_at: milestone.estimates_at,
        title: milestone.title,
        body: milestone.body
      }
    end

    CHART_POINTS_LIMIT = 24 * 14 # Hourly by default with 14 days

    def serialize_campaign_meta(campaign)
      {
        milestones: campaign
                      .milestones
                      .order(estimates_at: :desc)
                      .map { |milestone| serialize_campaign_milestone(milestone) },
        total_invited_count: campaign.contributors.where.not(referrer: nil).count,
        early_bird_until: campaign.early_bird_until,
        estimate_first_releasing_in: campaign.estimate_first_releasing_in,
        estimate_end_releasing_in: campaign.estimate_end_releasing_in,
        first_releasing_percentage: campaign.first_releasing_percentage,
        estimate_releasing_days_interval: campaign.estimate_releasing_days_interval,
        estimate_releasing_percentage_per_interval: ((100 - campaign.first_releasing_percentage).to_d / (campaign.estimate_end_releasing_in - campaign.estimate_first_releasing_in).to_i * campaign.estimate_releasing_days_interval).to_f.truncate(4),
        contribution_chart: campaign.hourly_contributions.order(timestamp: :asc).limit(CHART_POINTS_LIMIT).pluck(:timestamp, :amount).map { |i| [i[0], i[1].to_f.truncate(4)] }
      }
    end
end
