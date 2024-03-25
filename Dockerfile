FROM ruby:3.1.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set work directory
WORKDIR /app

# Add the rest of the code
ADD . /app

# Install gems
RUN bundle install

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["bundle", "exec", "rails", "db:migrate", "db:seed"]
