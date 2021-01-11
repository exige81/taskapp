class StaticPagesController < ApplicationController
  before_action :set_tasks

  def home
  end

  private
    def set_tasks
      @tasks = current_user.tasks if user_signed_in?
    end
end
