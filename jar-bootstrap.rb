require 'capybara'
require 'dotenv'
require 'selenium-webdriver'

Dotenv.load

class WantedlyAuto
  def initialize(session, url)
    @session = session
    @url = url
  end

  def cheer
    @session.find('.column-main .label', text: '応援する').click
    @session.all('.sns-checkbox-wrapper input[type="checkbox"]').each{|checkbox| checkbox.set(false) }
    wait_for_input
    @session.find('.ngdialog-content button', text: '応援する').click
  end

  def err(msg)
    $stderr.puts msg
    exit 1
  end

  def login
    err '.env.sampleを参考に.envファイルを作り、メールアドレス/パスワードを記入してください。' unless ENV['EMAIL'] && ENV['PASSWORD']

    @session.click_on 'ログイン'
    @session.click_on 'Facebookでログイン'
    @session.fill_in 'email', with: ENV['EMAIL']
    @session.fill_in 'pass', with: ENV['PASSWORD']
    @session.click_on 'loginbutton'
  end

  def need_login?
    @session.has_link? 'ログイン'
  end

  def run
    @session.visit @url
    login if need_login?
    wait_for_input unless @session.current_host == 'https://www.wantedly.com'
    if @session.has_css?('.column-main .label', text: '応援する')
      cheer
    else
      if /n/ === $stdin.gets
        # go next
      else
        cheer
      end
    end
  end

  def wait_for_input
    $stdin.gets 
  end
end

session = Capybara::Session.new(:selenium)

%w[
  https://www.wantedly.com/projects/110676
  https://www.wantedly.com/projects/120641
  https://www.wantedly.com/projects/132433
  https://www.wantedly.com/projects/110557
  https://www.wantedly.com/projects/136864
  https://www.wantedly.com/projects/133128
  https://www.wantedly.com/projects/130213
  https://www.wantedly.com/projects/122753
  https://www.wantedly.com/projects/123825
  https://www.wantedly.com/projects/115646
  https://www.wantedly.com/projects/83118
  https://www.wantedly.com/projects/84482
  https://www.wantedly.com/projects/132422
  https://www.wantedly.com/projects/127364
  https://www.wantedly.com/projects/135026
  https://www.wantedly.com/projects/133384
]
%w[
  https://www.wantedly.com/projects/134760
  https://www.wantedly.com/projects/122660
  https://www.wantedly.com/projects/125626
  https://www.wantedly.com/projects/136669
].each{|url| WantedlyAuto.new(session, url).run }
%w[
  https://www.wantedly.com/projects/136692
]
