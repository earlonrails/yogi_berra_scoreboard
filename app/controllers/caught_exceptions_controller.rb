require 'caught_exceptions_helper'

class CaughtExceptionsController < ApplicationController
  respond_to :html, :xml, :json

  include CaughtExceptionsHelper
  # GET /caught_exceptions
  # GET /caught_exceptions.json
  def index
    # @search_text_value = nil if params[:reset]
    search_text = (params[:search_text] || "")
    @search_text_value = search_text.dup
    @caught_exceptions = CaughtException.where(:dismissed.ne => true)
    if search_text.present?
      @caught_exceptions = CaughtException.search(search_text)
    end

    @caught_exceptions = @caught_exceptions.where(:project => params[:project]) if params[:project]
    @caught_exceptions = @caught_exceptions.order_by(:created_at => :desc).page(params[:page]).per(15)
    @projects = CaughtException.all.distinct(:project)

    respond_with(@caught_exceptions)
  end

  def dismiss
    line_one = CGI::unescape(params['line_one'])
    caught_exceptions = line_one ? CaughtException.in(:backtraces => [line_one]) : CaughtException.find(params[:error_id])

    if caught_exceptions
      caught_exceptions.update_all(:dismissed => true)
      json_return = { success: true }
    else
      render :json => { success: false }
    end

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Exceptions hidden!" }
      format.json { render json: json_return, status: 200 }
      format.js { render json: json_return, status: 200 }
    end
  end

  # GET /caught_exceptions/1
  # GET /caught_exceptions/1.json
  def show
    @caught_exception = CaughtException.find(params[:id])
    respond_with(@caught_exception)
  end

  def many_exceptions
    line_one = params[:line_one]
    @caught_exceptions = CaughtException.in(:backtraces => [line_one]).order_by(:created_at => :desc).page(params[:page]).per(15)
    @projects = CaughtException.all.distinct(:project)
    respond_with(@caught_exceptions)
  end

  def raw_query
    query = JSON.parse(params[:query])
    @caught_exceptions = CaughtException.where(query).order_by(:created_at => :desc).page(params[:page]).per(15)
    @projects = CaughtException.all.distinct(:project)

    respond_to do |format|
      format.html { render :partial => 'exceptions', :locals => { :caught_exceptions => @caught_exceptions } }
      format.json { render json: @caught_exceptions }
    end
  end


  def heat_map
    @map_reduced_caught_exceptions = CaughtException.group_by_first_line
    respond_with(@caught_exceptions)
  end
end
