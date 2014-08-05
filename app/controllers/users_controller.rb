class UsersController < ApplicationController
  before_action :authenticate_user!

	def show
		# Figures out own profile page if ID is passed in by URL or no; used to set profile as authenticated root
    if params[:id]
    	@user = User.find(params[:id])
		else
  		# Show the currently logged in user
  		@user = current_user
		end
		new_tip
	end

	def create
	  @user = User.create(user_params)
	end

	private

	def new_tip
  	@tip = current_user.tips.build
  end
end