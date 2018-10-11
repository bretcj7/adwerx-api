class StarsController < ApplicationController
  def index
    @star = Star.new
    @star.get_stars()
    @results = Star.all
  end

end
