class Tip < ActiveRecord::Base
	belongs_to :user
	belongs_to :recipient, :class_name => "User"

  validates :link, presence: true, :format => URI::regexp(%w(http https))
  before_save :scrape_with_grabbit
	serialize :images   # Store images array as YAML in the database  

  has_attached_file :image, :styles => { :full => "225x225#"}
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


  private

  # Scrape images, title, description
  def scrape_with_grabbit
    # I highly recommend passing the following call off to a Resque worker, or Delayed Job queue.
    # The reason is that Grabbit will attempt to access the remote URL. If there is a network problem,
    # or the remote URL is unavailable, the following line could hang up your Rails process.

    data = Grabbit.url(link)

    if data
      self.title = data.title
      self.description = data.description
      # Only runs if images were returned by Grabbit 
      unless data.images.nil?
        # Runs until an image is saved
        while self.image_file_name == nil
          geometry = Paperclip::Geometry.from_file(data.images.first)
          if geometry.width.to_i >= 225 && geometry.height.to_i >= 225
            self.image = URI.parse(data.images.first)
          else
            #Replace this with logic for dumping first image and moving to next one indefinitely
            self.image = URI.parse(data.images.second)
          end
        end 
      end
    end
  end
end
