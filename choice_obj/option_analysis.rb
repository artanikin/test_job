#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

class OptionAnalysis

	def parse(args)

		# Присваивание значений по умолчанию
		options = OpenStruct.new
		options.age    = (0..100)       # Диапазон значений лет 
		options.sale   = (0..1000000)   # Диапазон значений заработной платы
		options.growth = (0..200)       # Диапазон значений роста
		options.weight = (0..200)       # Диапазон значений веса
		options.num    = 10_000_000     # Количество объектов, которые будут загружены для поиска
		options.verbose = false         # Флаг, для более подробного отчета работы программы

		# Разбор принятых опций
		optparse = OptionParser.new do |opts|
			# Установка заголовка в Help
			opts.banner = "Usage: choise.rb [options]"

			opts.separator ""
			opts.separator "SPECIFIC OPTIONS:"

			# Разбор опций для свойств объекта
			opts.separator "    Set the range of values:"

			opts.on("--age [NUMBER,NUMBER]", Array, "Range of age.") do |range_age|
				# Обрабатываестя диапазон значений для свойства age
				options.age = get_validated_data(range_age, options.age)
			end

			opts.on("--sale [NUMBER,NUMBER]", Array, "Range of sale.") do |range_sale|
				# Обрабатываестя диапазон значений для свойства sale
				options.sale = get_validated_data(range_sale, options.sale)
			end

			opts.on("--growth [NUMBER,NUMBER]", Array, "Range of growth.") do |range_growth|
				# Обрабатываестя диапазон значений для свойства growth
				options.growth = get_validated_data(range_growth, options.growth)
			end

			opts.on("--weight [NUMBER,NUMBER]", Array, "Range of weight.") do |range_weight|
				# Обрабатываестя диапазон значений для свойства weight
				options.weight = get_validated_data(range_weight, options.weight)
			end


			opts.separator ""
			opts.on("-n", "--num [NUMBER]", "Number of objects.") do |n|
				# Обрабатывается значение количества объектов
				options.num = get_validate_num(n, options.num)
			end

			opts.on("-v", "--verbose", "Run verbosely.") do |v|
				# Проверяется, устанавливается опция verbose
				options.verbose = true if v
			end

			opts.separator ""
			opts.separator "COMMON OPTIONS:"

			opts.on_tail("-h", "--help", "Display this help message.") do
				# Вывод help к программе
				puts opts
				exit
			end

			opts.on_tail("--version", "Display the program version.") do
				# Отображение версии программы
				puts 'Choise Object version 1.0'
				exit
			end
		end

		begin
			optparse.parse!(args)

		rescue OptionParser::MissingArgument => ex
			# Отлавливает ошибку, если был пропущен аргумент у свойства
			puts ex
			exit
		
		rescue OptionParser::InvalidOption => ex
			# Отлавливает ошибку, если введено не правильное свойство
			puts ex
			exit
		end
		
		options
	end


	private

		def get_validated_data(input_opt, default_opt)
			# Возвращает проверенный на правильность диапазон значений
			options = input_opt[0..1] # Берет только первые значения 
			options = get_range(options, default_opt)
		end

		def get_range(options, default_opt)
			# Получает диапазонзначений
			result = []
			opt_size = options.size

			# Проверка, что значения были введены
			if opt_size > 0
				i = 0
				while i < opt_size
					if is_numeric? options[i]
						# Если значение в строке является числовым, то значение
						# переводится из строкового в числовое значение
						options[i] = options[i].to_i

						if options[i] < default_opt.first
							# Если значение меньше минимально возможного, то ему присваивается
							# значение минимально возможного
							options[i] = default_opt.first
						elsif options[i] > default_opt.last
							# Если значение больше максимально возможного, то ему присваивается
							# значение максимально возможного
							options[i] = default_opt.last
						end

						result << options[i]
					end
					i += 1
				end
			end

			if result.empty?
				# Если в result небыло добавлено ни одного значения, то ему присваивается
				# значение по умолчанию
				result = default_opt
			else
				# значение сортируются по возрастанию
				result.sort!

				if result.size > 1
					# Если result содержит больше одного значения, то из массива
					# переводится в диапазон
					result = result[0]..result[1]
				else 
					# Если result содержит одно значение, то диапазон состоит из 
					# одинаковых значений вначале и вконце
					result = result[0]..result[0]
				end
			end
			result
		end

		def get_validate_num(n, default)
			# Проверка, является ли значение в строке числом
			n = unless is_numeric? n
				# Если нет, то возвращается значение по умолчанию
				default
			else
				# Если да, то строка переводится в число по модулю
				n.to_i.abs
			end
		end

		def is_numeric?(object)
			# Проверка, является ли объект числом
			true if Float(object) rescue false
		end

end

# ----------------------------------------------------------------------- 

if __FILE__ == $0
	# Выводятся тестовые значения
	optparse = OptionAnalysis.new
	options = optparse.parse(ARGV)
	puts options
end
 