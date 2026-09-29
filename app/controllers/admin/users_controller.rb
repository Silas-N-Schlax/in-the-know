# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update]

    def index
      @query = params[:query]
      @users = User.search(@query).order(:name, :email)
    end

    def show; end

    def new
      @user = User.new(role: :admin)
    end

    def create
      @user = User.new(new_user_params)

      if @user.valid_for_invite?
        @user.invite!(current_user) { |user| user.skip_invitation = true }
        redirect_to admin_user_path(@user), flash: { setup_token: @user.raw_invitation_token }
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      if @user.update(role_params)
        redirect_to admin_users_path, notice: "#{@user.display_name} was updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def new_user_params
      params.expect(user: %i[email role])
    end

    def role_params
      params.expect(user: [:role])
    end
  end
end
