class ProjectConfigurationsController < ApplicationController
  # GET /project_configurations
  # GET /project_configurations.json
  def index
    @project_configurations = ProjectConfiguration.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @project_configurations }
    end
  end

  # GET /project_configurations/1
  # GET /project_configurations/1.json
  def show
    @project_configuration = ProjectConfiguration.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project_configuration }
    end
  end

  # GET /project_configurations/new
  # GET /project_configurations/new.json
  def new
    @project_configuration = ProjectConfiguration.new
    @projects = CaughtException.all.distinct(:project)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project_configuration }
    end
  end

  # GET /project_configurations/1/edit
  def edit
    @project_configuration = ProjectConfiguration.find(params[:id])
    @new_threshold = @project_configuration.thresholds.new
    @thresholds = @project_configuration.thresholds
    @example = CaughtException.where(:project => @project_configuration.name).first
  end

  # POST /project_configurations
  # POST /project_configurations.json
  def create
    @project_configuration = ProjectConfiguration.new(params[:project_configuration])
    @project_configuration.created_at = Time.now

    respond_to do |format|
      if @project_configuration.save
        format.html { redirect_to @project_configuration, notice: 'Configuration was successfully created.' }
        format.json { render json: @project_configuration, status: :created, location: @project_configuration }
      else
        format.html { render action: "new" }
        format.json { render json: @project_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /project_configurations/1
  # PUT /project_configurations/1.json
  def update
    @project_configuration = ProjectConfiguration.find(params[:id])

    respond_to do |format|
      if @project_configuration.update_attributes(params[:project_configuration])
        format.html { redirect_to @project_configuration, notice: 'Configuration was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_configurations/1
  # DELETE /project_configurations/1.json
  def destroy
    @project_configuration = ProjectConfiguration.find(params[:id])
    @project_configuration.destroy

    respond_to do |format|
      format.html { redirect_to project_configurations_url }
      format.json { head :no_content }
    end
  end
end
