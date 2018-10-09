/* This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author (s):
 *  Julien Peeters <contact@julienpeeters.fr>
 *
 * Copyright (C) 2009-2012 Julien Peeters

 * Copied from libgee/tests/testcase.vala.
 */

[CCode (gir_namespace = "DaF.UnitTest", gir_version = "1.2")] 
namespace Daf.UnitTest {

public abstract class AbstractTestCase : Object {

    private GLib.TestSuite test_suite;
    private Adaptor[] adaptors = new Adaptor[0];

    public delegate void TestMethod ();

    public AbstractTestCase (string name) {
        this.test_suite = new GLib.TestSuite (name);
    }

    public void add_test (string name, TestMethod test) {
        var adaptor = new Adaptor (name, test, this);
        this.adaptors += adaptor;

        this.test_suite.add (new GLib.TestCase (adaptor.name,
                                                adaptor.set_up,
                                                adaptor.run,
                                                adaptor.tear_down,
                                                sizeof(Adaptor)));
    }

    public void add_async_test (string name,
                                AsyncBegin async_begin,
                                AsyncFinish async_finish, int timeout = 200) {

        var adaptor = new Adaptor (name, () => { }, this);
        adaptor.is_async = true;
        adaptor.async_begin = async_begin;
        adaptor.async_finish = async_finish;
        adaptor.async_timeout = timeout;
        this.adaptors += adaptor;

        this.test_suite.add (new GLib.TestCase (adaptor.name,
                                                adaptor.set_up,
                                                adaptor.run,
                                                adaptor.tear_down,
                                                sizeof(Adaptor)));
    }

    /**
      * Keep in mind that the set_up/tear_down is called on every test case and not
      * just only the construction/destruction time.
      **/
    public virtual void set_up () {
    }

    public virtual void tear_down () {
    }

    public GLib.TestSuite get_suite () {
        return this.test_suite;
    }

    private class Adaptor {
        public string name { get; private set; }
        public int async_timeout { get; set; }

        private unowned TestMethod test;
        private AbstractTestCase test_case;

        public bool is_async = false;
        public unowned AsyncBegin async_begin;
        public unowned AsyncFinish async_finish;

        public Adaptor (string name, TestMethod test, AbstractTestCase test_case) {
            this.name = name;
            this.test = test;
            this.test_case = test_case;
        }

        public void set_up (void* fixture) {
            GLib.set_printerr_handler (this.printerr_func_stack_trace);
            Log.set_default_handler (this.log_func_stack_trace);
            this.test_case.set_up ();
        }

        private static void printerr_func_stack_trace (string? text) {
            if (text == null || str_equal (text, ""))
                return;

            stderr.printf (text);

            /* Print a stack trace since we've hit some major issue */
            GLib.on_error_stack_trace ("libtool --mode=execute gdb");
        }

        private void log_func_stack_trace (string? log_domain,
                                            LogLevelFlags log_levels,
                                            string message) {
            Log.default_handler (log_domain, log_levels, message);

            /* Print a stack trace for any message at the warning level or
             * above.
             */
            if ((log_levels & (LogLevelFlags.LEVEL_WARNING |
                                LogLevelFlags.LEVEL_ERROR |
                                LogLevelFlags.LEVEL_CRITICAL)) != 0) {
                GLib.on_error_stack_trace ("libtool --mode=execute gdb");
            }
        }

        public void run (void* fixture) {
            if (this.is_async) {
                try {
                    assert( wait_for_async (async_timeout, this.async_begin, this.async_finish) );
                } catch (GLib.Error err) {
                    message(@"Got exception while excuting asynchronous test: $(err.message)");
                    GLib.Test.fail ();
                }
            } else {
                this.test ();
            }
        }

        public void tear_down (void* fixture) {
            this.test_case.tear_down ();
        }
    }
}
}
