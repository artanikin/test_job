#!/usr/bin/env ruby

require 'fileutils'
require 'mechanize'
require 'ruby-progressbar'

BASE_DIR = './downloaded/'

def get_uri(uri)
	uri = 'http://' + uri unless uri.start_with?('http://', 'https://')
	page_uri = URI.parse(uri)
end

def make_dir(uri)
  # Если переданная директория уже существует,
  # то она удаляется и на её месте создается новая.
  # Если не существует, то создаётся.
  dir = get_name_dir(uri)
  FileUtils.remove_dir(dir) if File.directory? dir
  FileUtils.makedirs(dir)
  dir
end

def get_name_dir(uri)
  # Получение полного пути, для переданной директории
  uri = uri.gsub(/^(http:\/\/|https:\/\/)|(\?)/, "").split("\/").join('_')
  uri = "#{BASE_DIR}#{uri}"
end

def is_image?(uri)
  # Проверка, является ли переданное значение, именем изображения
  pattern = /[[:graph:]]+(\.png|\.jpg|\.jpeg|\.gif|\.bmp|\.ico|\.svg)/i
  uri.match(pattern)
end

def download(img_src, dir)

  agent = Mechanize.new
  agent.user_agent_alias = 'Linux Mozilla'

  img = agent.get(img_src)
  file_name = img.filename
  img.save "#{dir}/#{file_name}"

end

def split_arr(arr, count)
	part_count = (arr.count / count.to_f).ceil
	unless part_count == 0
		arr.each_slice(count)
	else
		[].each
	end
end

# ------------------------------------------------------------------------------

if __FILE__ == $0

	begin
		start_time = Time.now()
		report = { runtime: 0, uploaded: 0 }

		mutex = Mutex.new
		max_threads_count = 20

		if ARGV[0]
			uri = get_uri(ARGV[0])
		else
			raise "You not typed the parameters"
		end

		agent  = Mechanize.new
		agent.user_agent_alias = 'Linux Mozilla'
		page   = agent.get(uri)
		images = page.images

		threads = []

		unless images.empty?

		  uniq_src_img = []
		  images.each { |image| uniq_src_img << image.to_s if is_image? image.to_s }
		  uniq_src_img.uniq!

		  progress = ProgressBar.create(title: "Downloading",
		                              starting_at: 0, total: uniq_src_img.count,
		                              format: "%t: %p%%")

		  dir = make_dir(uri.to_s)

			uniq_src_img = split_arr(uniq_src_img, max_threads_count)

			uniq_src_img.map do |part_src|

			  part_src.each do |uri|
			  	threads << Thread.new do
					  download(uri, dir)
				  	mutex.synchronize { report[:uploaded] += 1; progress.increment }
			  	end
			  end
			end

			threads.each &:join

			report[:runtime] = Time.at((Time.now - start_time).to_f).strftime("%M:%S")
			puts "\nDownload complite!"

			puts "runtime = #{report[:runtime]}"
			puts "uploaded image = #{report[:uploaded]}"
		
		else
			raise "We're sorry. But on the page is not found pictures."
		end

	rescue Errno::ENOENT => error
		puts 'You entered not correct Uri.'

	rescue RuntimeError => error
		puts error

	rescue OpenSSL::SSL::SSLError => error
		puts error

	rescue => error
		puts error
	end

end