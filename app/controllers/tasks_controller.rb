class TasksController < ApplicationController
  allow_unauthenticated_access only: :index
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :toggle ]
  before_action :get_tasks, only: [ :index ]

  # GET /tasks
  def index
    @tasks ||= Current.user.tasks.all_tasks if authenticated?
    @task = Task.new if authenticated?
  end

  # GET /tasks/1
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = Current.user.tasks.new(task_params)

    respond_to do |format|
      if @task.save
        format.turbo_stream
        format.html { redirect_back fallback_location: root_url, notice: "Task was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to root_url, notice: "Task was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_url, notice: "Task was successfully destroyed." }
    end
  end

  # POST /tasks/1/toggle
  def toggle
    @task.update(completed: !@task.completed?)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_url }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  # Gets task based on /:sort parameter
  def get_tasks
    @sort = "all"
    return unless params[:sort]
    if params[:sort] == "incomplete"
      @tasks = Current.user.tasks.todo if authenticated?
      @sort = "incomplete"
    elsif params[:sort] == "completed"
      @tasks = Current.user.tasks.done if authenticated?
      @sort = "completed"
    end
  end

  def task_params
    params.require(:task).permit(:name, :completed, :completed_at)
  end
end
