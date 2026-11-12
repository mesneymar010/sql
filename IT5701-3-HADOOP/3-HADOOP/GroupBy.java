import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

// GENERIC GROUP BY for any CSV, no code change needed
// hadoop jar groupby.jar GroupBy <input> <output> <keyCol> <valueCol> <sum|avg|count|max|min> [filterCol=value]
// columns counted from 0, keyCol -1 = one total for whole file
public class GroupBy {

    public static class GroupMapper extends Mapper<Object, Text, Text, DoubleWritable> {
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            Configuration conf = context.getConfiguration();
            int keyCol = conf.getInt("keyCol", 0);
            int valueCol = conf.getInt("valueCol", 1);
            String filter = conf.get("filter", "");
            String[] data = value.toString().split(",");
            try {
                if (!filter.equals("")) {
                    String[] f = filter.split("=");
                    if (!data[Integer.parseInt(f[0])].trim().equals(f[1])) {
                        return;
                    }
                }
                double num = Double.parseDouble(data[valueCol].trim());
                String group = (keyCol < 0) ? "Total" : data[keyCol].trim();
                context.write(new Text(group), new DoubleWritable(num));
            } catch (Exception e) {
                // skips header or bad lines
            }
        }
    }

    public static class GroupReducer extends Reducer<Text, DoubleWritable, Text, DoubleWritable> {
        public void reduce(Text key, Iterable<DoubleWritable> values, Context context) throws IOException, InterruptedException {
            String op = context.getConfiguration().get("op", "sum");
            double sum = 0, count = 0;
            double max = -Double.MAX_VALUE, min = Double.MAX_VALUE;
            for (DoubleWritable v : values) {
                double d = v.get();
                sum += d;
                count++;
                if (d > max) max = d;
                if (d < min) min = d;
            }
            double result = sum;
            if (op.equals("avg")) result = sum / count;
            if (op.equals("count")) result = count;
            if (op.equals("max")) result = max;
            if (op.equals("min")) result = min;
            context.write(key, new DoubleWritable(result));
        }
    }

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        String[] a = new GenericOptionsParser(conf, args).getRemainingArgs();
        conf.setInt("keyCol", Integer.parseInt(a[2]));
        conf.setInt("valueCol", Integer.parseInt(a[3]));
        conf.set("op", a[4]);
        if (a.length > 5) conf.set("filter", a[5]);

        Job job = Job.getInstance(conf, "groupby");
        job.setJarByClass(GroupBy.class);
        job.setMapperClass(GroupMapper.class);
        job.setReducerClass(GroupReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(DoubleWritable.class);
        FileInputFormat.addInputPath(job, new Path(a[0]));
        FileOutputFormat.setOutputPath(job, new Path(a[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
