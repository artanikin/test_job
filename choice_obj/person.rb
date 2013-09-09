#!/usr/bin/env ruby

class Person
	# Объект, который заполняется случайными значениями
	attr_reader :age, :sale, :growth, :weight

	def initialize
		# Заполнение свойств случайными значениями
		@age = rand(100)
		@sale = rand(1000000)
		@growth = rand(200)
		@weight = rand(200)
	end

end

if __FILE__ == $0
	#  Вывод свойств объекта
	user = Person.new
	puts "Person.age    = #{user.age}"
	puts "Person.sale   = #{user.sale}"
	puts "Person.growth = #{user.growth}"
	puts "Person.weight = #{user.weight}"
end