#!/usr/bin/env ruby

require "pp"											 # Библиотека для более наглядного вывода
require "benchmark"								 # Библиотека для замера времени выполнения
require_relative "option_analysis" # Разбор опций
require_relative "person"          # Класс для создания объектов

def load_data(n)
	# Загрузка n-го количества обектов
	persons = []
	puts "Loading data...\n"
	n.times { persons << Person.new }
	puts "Was Successfully loaded #{n} objects.\n"
	persons
end

def search(objects, options)
	# Поиск объектов по заданным опциям
	result = []

	# Присваиваеются диапазоны введенных значений в переменные,
	# для большей удобочитаемости
	range_age    = options.age
	range_sale   = options.sale
	range_growth = options.growth
	range_weight = options.weight

	i = 0
	obj_size = objects.size
	# Просматривается весь массив объектов и если объект удовлетворяет условиям,
	# то он заносится массив результатов
	while i < obj_size do
		result << objects[i] if range_sale.include? objects[i].sale and range_weight.include? objects[i].weight and range_growth.include? objects[i].growth and range_age.include? objects[i].age
		i += 1
	end
	result 
end

#  ---------------------------------------------------------------------------

if __FILE__ == $0

	# Получение опций из введенный значений
	opt_analysis = OptionAnalysis.new()
	options = opt_analysis.parse(ARGV)

	# Получение объектов для поиска
	persons = load_data(options.num)

	# Если был установлен флаг verbose, то отобразистя отчет о времени выполнения поиска
	if options.verbose
		Benchmark.bmbm(7) do |x|
			x.report("Search:") { @objects = search(persons, options) }
		end
	else
		# Получение всех найденных объектов, в зависимотси от введеннх условий
		@objects = search(persons, options)
	end

	puts "\nSelected #{@objects.size} objects. "

	unless @objects.size == 0
		# Если объекты были найдены, то программа спрашивает: "Вывести ли их?"
		puts 'Display them?(y/n)'
		print "=> "
		input = gets.downcase.chomp
		# Если было введено "y" или "yes", то все объекты отобразятся
		pp @objects if input == "y" or input == "yes"
	end
		
end
















