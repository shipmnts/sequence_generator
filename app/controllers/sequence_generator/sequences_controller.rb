module SequenceGenerator
  class SequencesController < ApplicationController
    around_action :transactions_filter, only: %i[create]


    def create
      sequence = ::SequenceGenerator::Sequence.new(create_sequence_params)
      if sequence.save
        render json: sequence
      else
        api_error(status: :unprocessable_entity,
                  message: 'sequence creation failed',
                  errors: sequence.errors)
      end
    end

    def get
      return unless valid_params?(params, [:id])
      render json: ::SequenceGenerator::Sequence.find(params[:id])
    end

    def index
      return unless valid_params?(params, [:scope, :purpose])
      sequences = ::SequenceGenerator::Sequence.where(scope: params[:scope], purpose: params[:purpose])
      render json: sequences, status: :ok
    end

    private

    def transactions_filter
      ActiveRecord::Base.transaction do
        yield
      end
    end


    def create_sequence_params
      params.permit(:name,
                    :purpose,
                    :scope)
    end

  end
end