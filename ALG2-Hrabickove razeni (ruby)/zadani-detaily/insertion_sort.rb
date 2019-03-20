class Array
  # Sorts the array using insertion sort.
  # Returns the array itself.
  def insertion_sort!
    1.upto(self.size - 1) do |i|
      item = self[i]
      j = i - 1
      while j >= 0 && self[j] > item
        self[j + 1] = self[j]
        j -= 1
      end
      self[j + 1] = item
    end
    return self
  end
end
