Chin Family Clinic — website photos
===================================

Save image files HERE so paths work when you open pages locally (e.g. index.html)
and when the site is deployed with the same folder structure.

Root folder for all photos:
  assets/photos/

The site is wired for PNG (.png) files (see <img> and social meta tags in the HTML).
Recommended: at least ~1600px wide for hero; 1200–1600px wide for section/service images.
Landscape (16:9 or 4:3) works best — hero and section images use object-fit: cover unless noted.


MAIN SITE (HTML files in project root)
--------------------------------------
File name               Used on page / area
---------------------   ------------------------------------------
approach.png            index.html — hero banner (right column + homepage og:image)
who-we-help.png         who-we-help.html — image column
concierge.png           concierge.html — image column
about.png               about.html — portrait headshot (shown full-frame, not cropped)

home-hero.png           (optional — not referenced in HTML currently; spare asset)


SERVICE DETAIL PAGES (save in the services subfolder)
-----------------------------------------------------
Folder:  assets/photos/services/

File name               Service page
---------------------   ------------------------------------------
weight-metabolic.png    services/weight-metabolic.html
longevity.png           services/longevity.html
menopause-hormone.png   services/menopause-hormone.html
mens-health.png         services/mens-health.html
pcos.png                services/pcos.html
adhd.png                services/adhd.html
sports-medicine.png     services/sports-medicine.html
travel.png              services/travel.html
primary-care.png        services/primary-care.html
episodic.png            services/episodic.html
medical-forms.png       services/medical-forms.html


Other formats
-------------
To use JPEG or WebP instead, rename the files and update every matching path in the HTML
(see img src and og:image / twitter:image URLs), or use <picture> with <source type="...">.
