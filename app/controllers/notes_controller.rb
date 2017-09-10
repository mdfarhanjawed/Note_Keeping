class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  # GET /notes
  # GET /notes.json
  def index
    if params[:tags].present?
      @notes = Note.where(user_id: current_user).tag_with(params[:tags])
    else
      @notes = Note.where(user_id: current_user)
    end    
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
  end

  def permission    
    @note = Note.find(params[:note_id])
    @ownership = Permission.find_by(user_id: current_user, note_id: @note)
  end

  def give_permission    
    parent = Permission.find_by(user_id: current_user.id, note_id: params[:note_id])
    if parent.present?      
      parent.children.create(user_id: params[:user], note_id: params[:note_id], ownership: params[:ownership])
    end

    redirect_to notes_path
  end

  def sharing
    @sharing = Permission.where(user_id: current_user.id)
  end

  def shared_with
    @shared_with = Permission.where(user_id: current_user.id).to_a
  end

  def permission_denied  
    if params[:user_id].present?
      Permission.find_by(user_id: params[:user_id], note_id: params[:note_id]).destroy  
    end

    redirect_to notes_path
  end

  # GET /notes/new
  def new
    @note = Note.new(user_id: current_user.id)
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(note_params)


    respond_to do |format|
      if @note.save
        Permission.create(user_id: note_params[:user_id], note_id: @note.id)
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url, notice: 'Note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def note_params
      params.require(:note).permit(:body, :user_id, :ownership, :all_tags)
    end
end