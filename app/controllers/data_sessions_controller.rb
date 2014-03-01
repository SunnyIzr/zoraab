class DataSessionsController < ApplicationController
  def show_last_sub_pull
    @subs = DataSession.last.data
    render partial: "subs/upcoming_subs", locals: {subs: @subs}
  end
end
