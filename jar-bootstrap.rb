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
    @session.has_css?('.sns-checkbox-wrapper input[type="checkbox"]') or
      ask_manual('応援ウィンドウを表示')
    @session.all('.sns-checkbox-wrapper input[type="checkbox"]').each{|checkbox| checkbox.set(false) }
    @session.all('.sns-checkbox-wrapper input[type="checkbox"]').none?(&:checked?) or
      ask_manual('SNSオプションをアンチェック')
    @session.find('.ngdialog-content button', text: '応援する').click
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
    try { @session.click_on 'ログイン' }
      .check('ログインダイアログを表示') {
        @session.has_link?(href: 'https://www.wantedly.com/user/auth/facebook')
      }
    try { @session.find('a[href="https://www.wantedly.com/user/auth/facebook"]').click }
      .check('Facebookのログイン画面を表示') {
        @session.has_field?('email')
      }
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

  def try(&block)
    Action.new(block).try_twice
  end

  class Action
    def initialize(block)
      @action_block = block
    end

    def check(descripton, &block)
      @descripton = descripton
      @check_block = block
      self.retry unless @check_block.call
    end

    def try_twice
      @action_block.call
      self
    end

    def retry
      @action_block.call
      @check_block.call or ask_manual(@descripton)
    end
  end
end

WantedlyHacker.run
