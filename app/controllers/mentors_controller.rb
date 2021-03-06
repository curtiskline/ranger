class MentorsController < EventBasedController
  # GET /mentors
  # GET /mentors.json
  def index
    @mentors = policy_scope(@event.mentors)
    @mentors = @mentors.includes(:mentorship).includes(:involvement).
      includes(:mentee).includes(:shift)
    @mentors = order_by_params @mentors

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mentors }
    end
  end

  # GET /mentors/1
  # GET /mentors/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mentor }
    end
  end

  # GET /mentors/1/changes
  # GET /mentors/1/changes.json
  def changes
    @audits = order_by_params @mentor.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /mentors/new
  # GET /mentors/new.json
  def new
    @mentor = @event.mentors.build
    @mentor.mentorship = Mentorship.find params['mentorship_id'] if params['mentorship_id'].present?
    authorize @mentor
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mentor }
    end
  end

  # GET /mentors/1/edit
  def edit
  end

  # POST /mentors
  # POST /mentors.json
  def create
    @mentor = @event.mentors.build mentor_params
    @mentor.mentorship = Mentorship.find params['mentorship_id']
    authorize @mentor
    respond_to do |format|
      if @mentor.save
        format.html { redirect_to [@event, @mentor], notice: 'Mentor was successfully created.' }
        format.json { render json: @mentor, status: :created, location: @mentor }
      else
        format.html { render action: "new" }
        format.json { render json: @mentor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mentors/1
  # PUT /mentors/1.json
  def update
    respond_to do |format|
      if @mentor.update_attributes(mentor_params)
        format.html { redirect_to [@mentor.event, @mentor], notice: 'Mentor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mentor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mentors/1
  # DELETE /mentors/1.json
  def destroy
    @mentor.destroy

    respond_to do |format|
      format.html { redirect_to event_mentors_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @mentor
  end

  def load_subject_record_by_id
    @mentor = @event.mentors.find params[:id]
  end

  def default_sort_column
    'involvements.name'
  end

  private
  def mentor_params
    params.require(:mentor).
      permit(*policy(@mentor || Mentor.new).permitted_attributes)
  end
end
