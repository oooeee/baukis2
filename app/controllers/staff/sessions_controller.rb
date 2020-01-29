class Staff::SessionsController < Staff::Base
  skip_before_action :authorize

  def new
    if current_staff_member
      redirect_to :staff_root
    else
      @form = Staff::LoginForm.new
      render "new"
    end
  end

  def create
    @form = Staff::LoginForm.new(login_form_params)
    if @form.email.present?
      staff_member = StaffMember.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    if Staff::Authenticator.new(staff_member).authenticate(@form.password)
      if staff_member.suspended?
        flash.now.alert = "アカウントが停止されています。"
        render "new"
      else
        session[:staff_member_id] = staff_member.id
        session[:last_access_time] = Time.current
        redirect_to :staff_root, notice: "ログインしました。"
      end
    else
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render "new"
    end
  end

  def destroy
    session.delete(:staff_member_id)
    redirect_to :staff_root, notice: "ログアウトしました。"
  end

  private

  def login_form_params
    params.require(:staff_login_form).permit(:email, :password)
  end
end
