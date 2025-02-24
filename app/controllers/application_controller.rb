class ApplicationController < ActionController::Base
    rescue_from ActionController::RoutingError, with: :render_404


    def render_404
        respond_to do |format|
          format.html { render 'errors/404', status: :not_found }
          format.json { head :not_found }
        end
    end


    def migrate #ignore this method
        begin
          # Run the migrations
          ActiveRecord::MigrationContext.new(
            ActiveRecord::Migrator.migrations_paths,
            ActiveRecord::SchemaMigration
          ).migrate
          
          render plain: "Database migration completed successfully."
        rescue => e
          render plain: "Database migration failed: #{e.message}", status: :unprocessable_entity
        end
    end
end
