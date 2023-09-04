require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
    let(:image) { create(:image) }
    before(:each, except: [:method_to_skip]) do
        image
    end
    describe 'GET #index' do
        it 'renders the index template', :method_to_skip do
            get :index
            expect(response).to render_template(:index)
        end
    end
    describe 'GET #new' do
        it 'renders the new template', :method_to_skip do
            get :new
            expect(response).to render_template(:new)
        end
    end
    describe 'GET #show' do
        it 'returns a success response' do
        get :show, xhr: true, params: { id: image.id }, format: :js
        expect(response).to be_successful
        expect(response).to render_template('show')
        end
    end
    describe 'POST #create' do
        it 'creates a new image' do
            image_params = FactoryBot.attributes_for(:image)
            expect {
                post :create, params: { image: image_params }
            }.to change(Image, :count).by(1)
        end
        it "does not add annotation if key or value is empty" do
            image_params = FactoryBot.attributes_for(:image)
            expect {
                post :create, params: { image: image_params, annotation: [{key: "", value: ""}, {key: "k", value: "v"}] }
            }.to change(Image, :count).by(1).and change(Annotation, :count).by(1)
        end
        it "does not add image without a picture" do
            expect {
                post :create, params: { annotation: [{key: "k", value: "v"}] }
            }.to change(Image, :count).by(0).and change(Annotation, :count).by(0)
        end
        it "redirects to create new image template if saving image fails" do
            allow_any_instance_of(Image).to receive(:save).and_return(false)
            image_params = FactoryBot.attributes_for(:image)
            post :create, params: { image: image_params }
            expect(flash[:notice]).to eq('Could not add image')
            expect(response).to redirect_to(new_image_path)
        end
    end
    describe 'DELETE #destroy' do
        it 'deletes the image', :method_to_skip do
            image_to_delete = create(:image)
            expect {
                delete :destroy, params: { id: image_to_delete.id }
            }.to change { Image.count }.by(-1)
            expect(response).to redirect_to(images_path)
        end
    end
    describe 'DELETE #delete_key' do
        it 'deletes the key', :method_to_skip do
            annotation=Annotation.create(key: "key", value: "value", image_id: image.id)
            expect {
                delete :delete_key, params: { id: image.id, key: annotation.id }
            }.to change(Annotation, :count).by(-1)
            expect(response).to redirect_to(edit_image_path(image))
        end
    end
    describe 'PATCH #update' do
        it "edits the image", :method_to_skip do
            annotation=Annotation.create(key: "key", value: "value", image_id: image.id)
            new_picture = fixture_file_upload('/Users/inito/downloads/image3.avif', 'image/avif')
            new_key = 'new_key'
            new_value = 'new_value'

            patch :update, params: {
            id: image.id,
            image: {
                picture: new_picture,
                annotations: {
                "#{annotation.id}" => { id: annotation.id, key: new_key, value: new_value }
                }
            }
            }

            image.reload
            annotation.reload

            expect(image.picture).to be_attached
            expect(annotation.key).to eq(new_key)
            expect(annotation.value).to eq(new_value)
            expect(flash[:notice]).to eq('Image edited successfully')
            expect(response).to redirect_to(images_path)
        end
    end
    describe 'POST #add_metadata' do
        it "add new annotations", :method_to_skip do
            annotations= {
                "0"=>{"key"=>"abcd", "value"=>"dddd"},
                "1"=>{"key"=>"efgh", "value"=>"hhhh"}
            }
            post :add_metadata, params: {
                id: image.id,
                annotations: annotations
            }, format: :json
    
            image.reload
    
            expect(image.annotations.count).to eq(annotations.count)
            expect(response).to have_http_status(:success)
            expect(response.body).to eq({ status: 'success' }.to_json)
        end
        it "does not allow more than 10 annotations", :method_to_skip do
            annotations_list = []

            13.times do |i|
            annotations_list << {
                i.to_s => {
                "key" => "key#{i}",
                "value" => "value#{i}"
                }
            }
            end

            annotations = Hash[annotations_list.map(&:to_a).flatten(1)]
            post :add_metadata, params: {
                id: image.id,
                annotations: annotations
            }, format: :json
    
            image.reload
    
            expect(image.annotations.count).to eq(10)
            expect(response).to have_http_status(:success)
        end
        it "sends an error status if image is not saved", :method_to_skip do
            post :add_metadata, params: { id: image.id, annotations: { "0" => { "key" => "", "value" => "" } }, format: :json }
            expect(response).to have_http_status(:success) 
            expect(JSON.parse(response.body)).to eq({ 'status' => 'error' })
        end
    end
end
