class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :listing, :pricing, :description]
  before_action :authenticate_user!, except: [:show]
  before_action :is_authorized, only: [:listing, :pricing, :description, :photo_upload, :amenities, :location, :update]
  

  def index
    @rooms = current_user.rooms
  end

  def new
    @room = current_user.rooms.build
  end

  def create
    @room = current_user.rooms.build(room_params)
    if @room.save
      redirect_to listing_room_path(@room), notice: "Saved..."
    else
      render 'new', alert: "Something went wrong!"
    end
  end

  def show
    @photos = @room.photos
  end

  def listing
  end

  def pricing
  end

  def description
  end

  def photo_upload
    @photos = @room.photos
  end

  def amenities
  end

  def location
  end
  

  def update
    new_params = room_params
    new_params = room_params.merge(active: true) if is_ready_room
    if @room.update(new_params)
      flash[:notice] = "Saved..."
      redirect_to listing_room_path(@room)
      
    else
      flash[:notice] = "Something went wrong!"
      redirect_to :back
    end
  end
  
  #reservations
  def preload
    @room = Room.find(params[:id])
    
    today = Date.today
    
    reservations = @room.reservations.where("start_date >= ? OR end_date >= ?", today, today)
    render json: reservations
    
  end
  
  def preview
    @room = Room.find(params[:id])
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    output = {
      conflict: is_conflict(start_date, end_date, @room)
    }
    
    render json: output
  end


  private
  
    def is_conflict(start_date, end_date, room)
      @check = room.reservations.where("? < start_date AND end_date < ?", start_date, end_date)
      @check.size > 0 ? true : false
    end

    def set_room
      @room = Room.find(params[:id])
    end

    def is_authorized
      @room = Room.find(params[:id])
      redirect_to root_path, alert: "You don't have permission" unless current_user.id == @room.user_id
    end

    def room_params
      params.require(:room).permit(:home_type, :room_type, 
        :accomodate, :bed_room, 
        :bath_room, :listing_name, 
        :summary, :address,
        :is_tv, :is_kitchen, 
        :is_air, :is_heating, 
        :is_internet, :price, :active)
    end
    
    def is_ready_room
      !@room.active && !@room.price.blank? && !@room.listing_name.blank? && !@room.photos.blank? && !@room.address.blank?
    end
end
