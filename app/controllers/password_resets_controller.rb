# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :find_user,          only: %i[edit update]
  before_action :valid_user,         only: %i[edit update]
  before_action :check_expiration,   only: %i[edit update]
  # Case (1)

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Please check your email for password reset link'
      redirect_to root_url
    else
      flash.now[:danger] = 'Invalid activation link'
      render 'new'
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?                  # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)          # Case (4)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit'                                     # Case (2)
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Before filters

  def find_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    user_is_activated_and_authenticated = @user&.activated? &&
                                          @user&.authenticated?(:reset, params[:id])

    redirect_to root_url unless user_is_activated_and_authenticated
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end
end
