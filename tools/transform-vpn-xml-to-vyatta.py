import lxml.etree as ET
import sys

if len(sys.argv) != 3:
    print "USAGE "+sys.argv[0]+" XML_FILE_TO_PARSE XSLT_FILE"
    sys.exit(1)

xml_filename = sys.argv[1]
xsl_filename = sys.argv[2]


dom = ET.parse(xml_filename)
xslt = ET.parse(xsl_filename)
transform = ET.XSLT(xslt)
newdom = transform(dom)
print newdom
