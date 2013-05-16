require 'caught_exceptions_helper'

class CaughtExceptionsController < ApplicationController
  include CaughtExceptionsHelper
  # GET /caught_exceptions
  # GET /caught_exceptions.json
  def index
    search_text = params[:search_text]
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
      @caught_exceptions = additive_query.page(params[:page]).per(10)
    else
      @caught_exceptions = if params[:project]
        CaughtException.where(:dismissed.ne => true, :project => params[:project]).page(params[:page]).per(10)
      else
        CaughtException.where(:dismissed.ne => true).page(params[:page]).per(10)
      end
    end
    @projects = @caught_exceptions.collect(&:project).uniq.compact

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @caught_exceptions }
    end
  end

  def dismiss 
   caught_exception = CaughtException.find(params[:error_id])
   if caught_exception 
      caught_exception.update_attribute(:dismissed, true)
      render json: { success: true } 
   else 
      render json: { success: false } 
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
end
