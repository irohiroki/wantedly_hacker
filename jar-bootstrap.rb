require 'capybara'
require 'dotenv'
require 'selenium-webdriver'

Dotenv.load

def ask_manual(descripton)
  print descripton + 'できませんでした。手作業で完了してからReturnを押してください。'
  $stdin.gets 
end

class WantedlyHacker
  def self.run
    new.run
  end

  def check_credentials
    unless ENV['EMAIL'] && ENV['PASSWORD']
      err '.env.sampleを参考に.envファイルを作り、メールアドレス/パスワードを記入してください。'
    end
  end

  def cheer
    @session.find('.column-main .label', text: '応援する').click
    @session.has_css?('.ProjectSupportModal--checkboxWrapper') or
      ask_manual('応援ウィンドウを表示')
    @session.all('.ProjectSupportModal--checkboxWrapper input[type="checkbox"]').each{|checkbox| checkbox.set(false) }
    @session.all('.ProjectSupportModal--checkboxWrapper input[type="checkbox"]').none?(&:checked?) or
      ask_manual('SNSオプションをアンチェック')
    @session.find('button', text: '応援する').click
  end

  def cheer_printing(url)
    print url
    if @session.has_css?('.column-main .label', text: '応援する')
      cheer
      puts ' 完了'
    else
      puts ' 応援済み'
    end
  end

  def err(msg)
    $stderr.puts msg
    exit 1
  end

  def login
    @session.click_on 'ログイン'
    @session.has_link?(text: 'Facebook') or
      ask_manual('ログインダイアログを表示')
    @session.click_on 'Facebook'
    @session.has_field?('email') or
      ask_manual('Facebookのログイン画面を表示')
    @session.fill_in 'email', with: ENV['EMAIL']
    @session.fill_in 'pass', with: ENV['PASSWORD']
    @session.click_on 'loginbutton'
  end

  def need_login?
    @session.has_link? 'ログイン'
  end

  def open_session
    @session = Capybara::Session.new(:selenium)
  end

  def process(url)
    @session.visit(url)
    login if need_login?
    @session.current_host == 'https://www.wantedly.com' or ask_manual('ログイン')
    cheer_printing(url)
  end

  def read_urls
    @urls = File.open('urls.txt').each_line.map(&:chomp)
  rescue
    err 'urls.txtというファイルにWantedlyのURLを書いてください。URLは1行に1つにしてください。'
  end

  def run
    read_urls
    check_credentials
    open_session
    @urls.each do |url|
      process(url)
    end
  end
end

WantedlyHacker.run
