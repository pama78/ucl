# Provides the ability to generate all permutations of an array passed to its constructor.
class PermutationGenerator
  # Creates a new instance of the generator, +array+ is the array of which the permutations
  # will be generated.
  def initialize(array)
    @array = array
    @factorial = 1
    2.upto(@array.length) { |i| @factorial *= i }
    @k = 0
  end

  # Returns the next permutation. Returns nil when all permutations have been already generated.
  def next
    return nil if @k == @factorial
    if @array.length == 0
      @k += 1
      return []
    end
    factorial = @factorial / @array.length
    array = @array.clone
    (@array.length - 1).times do |i|
      tempi = (@k / factorial) % (@array.length - i)
      tempa = array[i + tempi]
      (i + tempi).downto(i + 1) do |j|
        array[j] = array[j - 1]
      end
      array[i] = tempa
      factorial /= @array.length - i - 1
    end
    @k += 1
    return array
  end
end
