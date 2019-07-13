---
title: Java调用本地脚本
date: 2019-02-02 15:49:57
categories: java
top: 4
---

### 1背景

java虽然很强大，但是在处理一些特定的工作的时候，一些脚本语言还有有着得天独厚的优势，例如在linux服务器上进行一些列的部署操作，就需要调用shell脚本，亦或者我们需要进行一些科学计算，多方研究表明python有相应的第三方库可以完成需求，并且性能不差，此时我们便有必要调用python脚本。

### 2举例

我们可以使用java自带的`Runtime.getRuntime().exec()`方法进行调用，先来看一个调用python脚本的例子吧。

```java
public class InvokePyDemo {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("please input a number: ");
        String num = scanner.next();
        Process process = null;
        /**
         * @参数1：“python”是要调用的脚本类型 
         * @参数2： “<dir>/<name>.py”是脚本具体的路径，根据需要使用相对路径或绝对路径
         * @参数3：这是给脚本传递的第一个参数，参数数量不限
         *        python可使用sys.argv[1]接受传入的第一个参数。以此类推
         */
        String[] args1 = new String[]{"python", "<dir>/<name>.py", num};
        try {
            process = Runtime.getRuntime().exec(args1);
            BufferedReader in = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                System.out.println(line);
            }
            in.close();
            process.waitFor();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

