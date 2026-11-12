import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class Payroll {

    // MAPPER : one line -> (key, value)    key = group by column, value = number
    public static class PayrollMapper extends Mapper<Object, Text, Text, IntWritable> {
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            String[] data = value.toString().split(",");
            try {
                String dept = data[2].trim();
                int salary = Integer.parseInt(data[3].trim());
                context.write(new Text(dept), new IntWritable(salary));
            } catch (Exception e) {
                // skips header or bad lines
            }
        }
    }

    // REDUCER : (key, list of values) -> (key, result)
    public static class PayrollReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable v : values) {
                sum += v.get();
            }
            context.write(key, new IntWritable(sum));
        }
    }

    // DRIVER : same for every question
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        String[] paths = new GenericOptionsParser(conf, args).getRemainingArgs();
        Job job = Job.getInstance(conf, "payroll");
        job.setJarByClass(Payroll.class);
        job.setMapperClass(PayrollMapper.class);
        job.setReducerClass(PayrollReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.addInputPath(job, new Path(paths[0]));
        FileOutputFormat.setOutputPath(job, new Path(paths[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
