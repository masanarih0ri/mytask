class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page]).per(30)

    # csvクラスメソッドを呼び出して使う
    respond_to do |format|
      # htmlについては何もしない
      format.html
      # csvの場合はsend_dataメソッドを「使ってレスポンスを送り出し、送り出したデータをブラウザからダウンロードできるようにする
      # format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.shrftime('%Y%m%d%S').csv}" }
      format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def import
    current_user.tasks.import(params[:file])
    redirect_to tasks_url, notice: "タスクを追加しました"
  end

  def show
  end

  def new
    @task = Task.new
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def create
    @task = current_user.tasks.new(task_params)

    if params[:back].present?
      render :new
      return
    end

    if @task.save
      TaskMailer.creation_email(@task).deliver_now
      SampleJob.perform_later
      redirect_to @task, notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @task.update!(task_params)
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を更新しました。"
  end

  def destroy
    @task.destroy
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を削除しました。"
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  # このコントローラー上でタスクに関するログだけを出力したい場合
  # def task_logger
  #   @task_logger || = Logger.new('log/task.log', 'daily')
  # end
  #
  # task_logger.debug('taskのログを出力')
end
