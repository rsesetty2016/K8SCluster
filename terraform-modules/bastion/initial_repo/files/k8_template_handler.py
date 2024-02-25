import json
import os, sys

required_fields = ["template-file",  "out-file"]
optional_fields = ["data-file"]

def print_usage():
    print("./python k8_template_handler.py \"key=value pairs seperated by space\"")
    print("Required fields:")
    print("\ttemplate-file=template_file")
    print("\tdata-file=json_file_with_data")
    print("\tout-file=output_filename")
    print("")


def process_list(t_data, k, v):
    new_string = ""
    for line in t_data.split("\n"):
        if "{{%s}}" % k in line:
            for item in v:
              new_s1 = line.replace("{{%s}}" % k, item)
              new_string += new_s1 + "\n"
        else:
           new_string += line + "\n"
    return new_string


def process_string(t_data, k, v):
    return t_data.replace("{{%s}}" % k, v)

def process_data(args):
   if not os.path.isfile(args['template-file']):
      print("Template file: %s not found ... " % args['template-file'])
      sys.exit(0)
   if 'data-file' in args and os.path.isfile(args['data-file']):
      with open(args['data-file']) as fp:
         data = json.load(fp)
   else:
      data = {}

   for k, v in args.items():
      if k in required_fields or k in optional_fields:
         continue
      if "[" in v and "]" in v:
           v = v.replace("[", "")
           v = v.replace("]", "")
           if "," in v:
               data[k] = v.split(",")
           else:
               data[k] = []
               data[k].append(v)
      else:
           data[k] = v

   template_file = args['template-file']
   if not os.path.isfile(template_file):
      print("File: %s is not found " % template_file)
      sys.exit(0)

   with open(template_file) as f_temp:
      t_data = f_temp.read()

   for k in data:
       if isinstance(data[k], list):
           t_data = process_list(t_data, k, data[k])
       else:
           t_data = process_string(t_data, k, data[k])
   with open(args['out-file'], "w") as fp:
       fp.write(t_data)


if __name__ == "__main__":
   if len(sys.argv) > 1:
      args = sys.argv[1]
      if "-h" in args:
         print_usage()
   else:
      print_usage()
      sys.exit(0)
   arguments = {}
   for arg in args.split():
      k, v = arg.split("=")
      arguments[k] = v
   for f in required_fields:
       if f not in arguments:
          print_usage()
          sys.exit(0)
   process_data(arguments)
