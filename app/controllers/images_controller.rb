class ImagesController < ApplicationController

    before_action :params_image, only: [:create]
    # before_action :annotation_params, only: [:create]
    before_action :set_image, only: [:show, :destroy, :edit, :add_metadata, :update, :delete_key]

    def index
        @images=Image.all
    end

    def new
        @image=Image.new
    end

    def show
        @images=Image.all
        respond_to do |format|
            format.js
        end
    end

    def create
        if params[:image]!=nil && params[:image][:picture]!=nil
            @image=Image.new(params_image)
            if params[:annotation]
                params[:annotation].each do |annotation|
                    if annotation[:key]!='' && annotation[:value]!=''
                        @annotation=Annotation.create(annotation_params(annotation))
                        @image.annotations << @annotation
                    else 
                        flash[:notice]="Empty key or value, can't add"
                    end
                end
            end
            if @image.save
                flash[:notice]="Image uploaded"
                redirect_to images_path
            else
                flash[:notice]="Could not add image"
                redirect_to new_image_path
            end
        else
            flash[:alert]="Image must be added"
            redirect_to new_image_path
        end
    end

    def destroy
        @image.destroy
        flash[:alert]="Image deleted"
        redirect_to images_path
    end

    def edit
    end

    def add_metadata
        if params[:annotations]
            params[:annotations].each do |annotation|
                if @image.annotations.count < 10
                    @annotation=Annotation.create(key: annotation[1][:key], value: annotation[1][:value])
                    @image.annotations << @annotation
                else
                    respond_to do |format|
                        format.json { render json: {status: "error", message: "Added upto 10 keys"} }
                    end
                    return
                end
            end
        end
        respond_to do |format|
            if @image.save
                format.json { render json: { status: "success" } }
            else
                format.json { render json: { status: "error" } }
            end
        end
    end

    def update
        if params[:image]
            @image.update(picture: params[:image][:picture])
        end
        params[:image][:annotations].each do |annotation|
            @an=Annotation.find(annotation[1][:id])
            @an.update(key: annotation[1][:key], value: annotation[1][:value])
        end

        flash[:notice]="Image edited successfully"
        redirect_to images_path
    end

    def delete_key
        @image.annotations.delete(params[:key]) 
        @image.save
        flash[:alert]="Key deleted"
        redirect_to edit_image_path(@image)
    end

    private
    def set_image
        @image=Image.find(params[:id])
    end

    def params_image
        params.require(:image).permit(:picture) if params[:image]
    end

    def annotation_params(annotation_params)
        annotation_params.permit(:key, :value)
    end

end