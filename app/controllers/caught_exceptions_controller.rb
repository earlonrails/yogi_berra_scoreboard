require 'caught_exceptions_helper'

class CaughtExceptionsController < ApplicationController
  include CaughtExceptionsHelper
  # GET /caught_exceptions
  # GET /caught_exceptions.json
  def index
    # @search_text_value = nil if params[:reset]
    search_text = (params[:search_text] || "")
    @search_text_value = search_text.dup
    @caught_exceptions = CaughtException.where(:dismissed.ne => true)
    if search_text.present?
      search_array = parse_search_text(search_text)
      additive_query = nil
      search_array.each do |element|
        if additive_query
          additive_query.merge(CaughtException.send(element[:type], element[:field], element[:query]))
        else
          additive_query = CaughtException.send(element[:type], element[:field], element[:query])
        end
      end
      @caught_exceptions = additive_query.merge(@caught_exceptions)
    end

    @caught_exceptions = @caught_exceptions.where(:project => params[:project]) if params[:project]
    @caught_exceptions = @caught_exceptions.order_by(:created_at => :desc).page(params[:page]).per(15)
    @projects = CaughtException.all.distinct(:project)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @caught_exceptions }
    end
  end

  def dismiss
   caught_exception = CaughtException.find(params[:error_id])
   if caught_exception
      caught_exception.update_attribute(:dismissed, true)
      render :json => { success: true }
   else
      render :json => { success: false }
   end
  end

  # GET /caught_exceptions/1
  # GET /caught_exceptions/1.json
  def show
    @caught_exception = CaughtException.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @caught_exception }
    end
  end

  def many_exceptions
    line_one = params[:line_one]
    @caught_exceptions = CaughtException.in(:backtraces => [line_one]).order_by(:created_at => :desc).page(params[:page]).per(15)
    @projects = CaughtException.all.distinct(:project)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @caught_exceptions }
    end
  end

  def heat_map
    @map_reduced_caught_exceptions = CaughtException.group_by_first_line

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @caught_exceptions }
    end
  end
end
