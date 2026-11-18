# Lets the signed-in user change their email and/or password.
class AccountsController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(account_params)
      redirect_to root_path, notice: "Your account has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def account_params
      params.expect(user: [ :email, :password, :password_confirmation, :password_challenge ]).tap do |p|
        # has_secure_password only checks the current password when a
        # challenge is present, so always require one (blank fails).
        p[:password_challenge] = p[:password_challenge].to_s
      end
    end
end
