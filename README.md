# Analog Metadata
A Lightroom plugin for matching analog film metadata and exporting it to files. Based loosely on [ leaf 500's film log](https://github.com/aleguna/FilmLog-LR)

![Screenshot showing the interface for matching frames from crown and flint](./img/screenshot.png)

## How to use

Export your roll with the "Export for ExifTool" option. Then take the zip that produces and put it in the folder with the scans you want to match it to. Then use `Library > Plug-in Extras > Import Analog Metadata ...` while you have the folder open in Lightroom. The plugin will match the frames based on filename and let you review the matches before applying the metadata to the photos.

## Features

### Metadata Import
- **Crown & Flint Integration**: Import film roll metadata from Crown & Flint JSON files
- **Automatic Frame Matching**: Match imported metadata to photos in your Lightroom catalog based on folder structure
- **Visual Dialog**: Interactive import dialog to review and confirm metadata before applying to photos

### Film Roll Metadata Fields
Track comprehensive information about your analog film rolls:
- **Roll Information**: Roll name, UID, status, creation time, and comments
- **Camera Details**: Camera name and format (e.g., 35mm, medium format)
- **Film Stock**: Emulsion name, box ISO, and rated ISO
- **Roll Thumbnail**: Visual reference for the roll

### Per-Frame Metadata Fields
Store detailed metadata for each individual frame:
- **Exposure Settings**: 
  - Shutter speed (e.g., 1/125, 1/500)
  - F-stop/aperture
  - Focal length
- **Lens Information**: Lens name with intelligent parsing from LensMake, LensModel, and LensInfo
- **Location Data**: GPS coordinates (latitude/longitude) and locality/title
- **Time Information**: Local capture time in ISO 8601 format
- **Frame Notes**: Frame index, comments, and thumbnails

### Metadata Export
- **ExifTool Integration**: Write analog metadata to image files during export using ExifTool
- **Custom Export Filter**: Export analog metadata by adding to any export preset
- **Smart Field Mapping**: Automatically maps Lightroom plugin fields to appropriate EXIF/XMP tags
- **Batch Processing**: Process multiple photos efficiently during export

### Browsable and Searchable
All metadata fields are:
- **Browsable** in Lightroom's metadata panel
- **Searchable** using Lightroom's search and filter features
- **Available** for smart collections and other organizational tools

### Cross-Platform Support
- Includes ExifTool binaries for macOS
- Built for Lightroom Classic SDK 9.0 (compatible with SDK 2.0+)
