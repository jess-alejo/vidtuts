class TagsController < ApplicationController
  def index
    @tags = Tag.order(course_tags_count: :desc)
    authorize @tags
  end

  def create
    tag = Tag.new(permitted_params)

    if tag.save
      render json: tag
    else
      render json: { errors: tag.errors.full_messages }
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    authorize @tag
    @tag.destroy!
    redirect_to tags_path, notice: 'Tag was successfully destroyed.'
  end

  private

  def permitted_params
    params.require(:tag).permit(:name)
  end
end
